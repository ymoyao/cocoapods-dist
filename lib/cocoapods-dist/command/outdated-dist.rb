module Pod
    class Command
        class Outdated < Command
            def public_updates
                updates
            end
        end
    end
end