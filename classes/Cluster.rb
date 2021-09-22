require('mpi')
require('parallel')
require_relative('./Dispatcher')

class Cluster

    private
    attr_accessor(:master, :workers)

    def initialize
        @master = {}
        @workers = []
    end

    public

    def set_master(master)
        if (
            (master.class.to_s === 'Hash') and
            master.key?('hostname') and
            master.key?('username') and
            master.key?('password')
        )
            @master = master
        else
            abort('set_master(hash) hash is wrong')
        end
    end

    def add_worker(worker)
        if (
            (worker.class.to_s === 'Hash') and
            worker.key?('hostname') and
            worker.key?('username') and
            worker.key?('password') and
            worker.key?('program') and
            worker.key?('command')
        )
            @workers << worker
            @workers = @workers.uniq
        else
            abort('add_worker(hash) hash is wrong')
        end
    end

    def run
        workers_size = @workers.size
        MPI.Init
        world = MPI::Comm::WORLD
        world_size = world.size
        if ((workers_size + 1) === world_size)
            world_rank = world.rank
            if(!@workers[world_rank].nil?)
                dispatcher = Dispatcher.new(@master, @workers[world_rank])
                world.Send(dispatcher.job, (world_size - 1), 0)
            else
                Parallel.map(0..(workers_size - 1), in_threads: workers_size) do |parallel|
                    output_worker = ("\x00" * 1024)
                    world.Recv(output_worker, parallel, 0)
                    output = output_worker.gsub("\x00", '')
                    pp(output)
                end
            end
        end
        MPI.Finalize
    end

end