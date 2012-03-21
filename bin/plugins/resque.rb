if Object.const_defined?("Resque")
  class SystemInspector
    alias :load_all_without_resque :load_all

    def load_all
      load_all_without_resque
      load @platform.resque
    end

    module OSX
      def self.resque
        ResqueInstrumentation.utilization_stats
      end
    end

    module Linux
      def self.resque
        ResqueInstrumentation.utilization_stats
      end
    end

    module ResqueInstrumentation
      # provide simple stats about resque utilization on this server
      def self.utilization_stats
        host_filter  = Proc.new{|w| w.hostname == hostname}
        idle_filter  = Proc.new{|w| w.idle?}
        workers      = Resque.workers.select(&host_filter)
        busy_workers = Resque.working.select(&host_filter).reject(&idle_filter)
        return {} if workers.blank?

        worker_count = workers.count
        busy_count   = busy_workers.count
        {
          "workers.count"           => workers_count,
          "workers.busy"            => busy_count,
          "workers.idle"            => workers_count - busy_count,
          "workers.utilization_pct" => busy_count.to_f / workers_count * 100
        }
      end

      def self.hostname
        @hostname ||= `hostname`.chomp
      end
    end
  end
end
