module Pod
    class Command
        class Spec < Command
            def pubulic_spec_and_source_from_spce(spec, version_filter = false)
                sets = config.sources_manager.search_by_name(spec)

                if sets.count == 1
                  set = sets.first
                elsif sets.map(&:name).include?(spec)
                  set = sets.find { |s| s.name == spec }
                else
                  names = sets.map(&:name) * ', '
                  raise Informative, "More than one spec found for '#{spec}':\n#{names}"
                end
        
                best_spec, spec_source = spec_and_source_from_set(set)
                best_spec
            end
        end
    end
end