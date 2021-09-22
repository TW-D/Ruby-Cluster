require('net/ssh')

class Dispatcher

    private
    attr_accessor(:workspace, :master, :worker, :output)

    def initialize(master, worker)
        @workspace = "/tmp/worker_#{SecureRandom.hex(8)}/"
        @master = master
        @worker = worker
        @output = ""
    end

    private

    def execute(command)
        begin
            Net::SSH.start(
                @worker['hostname'],
                @worker['username'],
                :password => @worker['password']
            ) do |ssh|
                @output = ""
                ssh.exec!(command) do |channel, stream, data|
                    #
                    # DEBUG
                    # pp(data)
                    #
                    @output << data if (stream == :stdout)
                end
            end
        rescue Exception => exception
            @output = exception.message
            false
        else
            true
        end
    end

    def setup
        if (self.execute("mkdir #{@workspace}"))
            self.execute("sshpass -p #{@master['password']} scp -o 'UserKnownHostsFile=/dev/null' -o 'StrictHostKeyChecking=no' -r #{@master['username']}@#{@master['hostname']}:#{@worker['program']} #{@workspace}")
        end
    end

    def start
        self.execute("cd #{@workspace} && #{@worker['command']}")
    end

    def output
        @output
    end

    def cleanup
        self.execute("rm -r #{@workspace}")
    end

    public

    def job
        self.setup
        self.start
        output = self.output
        self.cleanup
        output
    end

end