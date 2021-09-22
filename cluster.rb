require_relative('./classes/Cluster')

cluster = Cluster.new

cluster.set_master(
    {
        'hostname' => "master.home",
        'username' => "pi",
        'password' => "raspberry"
    }
)

cluster.add_worker(
    {
        'hostname' => "worker-0.home",
        'username' => "pi",
        'password' => "raspberry",
        'program' => (Dir.pwd + "/programs/worker-0/*"),
        'command' => "/usr/bin/bash ./main.sh"
    }
)

cluster.add_worker(
    {
        'hostname' => "worker-1.home",
        'username' => "pi",
        'password' => "raspberry",
        'program' => (Dir.pwd + "/programs/worker-1/*"),
        'command' => "/usr/bin/bash ./main.sh"
    }
)

cluster.run