function generate_config(outfile=nothing)
    if isnothing(outfile)
        outfile = "config.yml"
    end
    basic_config = """
    # basic simulation setup
    setup:
      # Used for initializing the random number generator.
      # The same seed wit the same data will give the same output
      random_seed: 123456789
      # Average time in milliseconds for ransomware to encrypt 1 GB of Data
      # average time for single core AES256 encryption is 456 milliseconds
      average_time_to_encypt_gb: 456
      # count of how many servers a server can attempt to attack at once
      attack_parallelism: 1
      # time in milliseconds between a server becoming infected and encrpytion
      # beginning average time is 300 milliseconds - not currently used
      infect_to_encryption: 300
      # time in hours it takes for a forensics analysis to complete,
      # and the restoration can begin
      forensics: 24
      # average time to restore 1 GB of data in milliseconds
      restore_time: 60000
      # potential improvements to recovery speed, defined by the stage it
      # impacts (forensics and / or restore), and the improvement as an
      # improvement % i.e 0.2 is a 20% improvement or 1.2x faster,
      # 2 is a 200% improvement or 3x faster
    post_ante:
    - name: Snapshot Recovery
      estimated_improvement: 2
      stages:
      - restore

    - name: Automation
      estimated_improvement: 0.2
      stages:
        - restore
        - forensics

    - name: Better Forensics
      estimated_improvement: 2
      stages:
        - forensics

    # defines the servers within the simulation, it is best to include all
    # servers within the estate and mark those that cannot be affected, either
    # due to network segementation, non-vulnerable OS, fully patched, etc,
    # as susceptiable: false.
    # system_id should be a unique identifier such as the hostname
    # disk_size_gb is the disk size in full GB (Integers only)
    # Infected allows for a specific server to be the point of infection
    # if not servers are found with infected: true, a random server will be
    # chosen as the point of infection
    servers:
    - system_id: server1
      disk_size_gb: 512
      infected: false
      susceptible: true
 """
f = open(outfile, "w")
write(f, basic_config)
close(f)
end
