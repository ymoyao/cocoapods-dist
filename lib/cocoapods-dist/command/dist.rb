module Pod
  class Command
    class Dist < Command
      include RepoUpdate
      include ProjectDirectory
      require 'cocoapods/command/spec'
      require 'cocoapods/command/outdated.rb'
      require 'cocoapods/executable.rb'

      require 'cocoapods-dist/command/spec-dist.rb'
      require 'cocoapods-dist/command/outdated-dist.rb'

      extend Executable
      executable :git

      self.summary = 'a cocoapods plugin to display particular component outdated information In a xcode project.'

      self.description = <<-DESC
      --tag: show tags only
      --commit: show all addtion commits
      DESC

      def self.options
        [
          ['--tag', 'show tags only'],
          ['--commit', 'show all addtion commits'],
        ].concat(super)
      end

      def initialize(argv)
        @tag = argv.flag?('tag', true)
        @commit = argv.flag?('commit', false)
        @name = argv.shift_argument
        super
      end

      def validate!
        super
        help! 'A Pod name is required.' unless @name
      end

      def run

        validate!

        #clone module to cache dir && fetch newest log
        cloneToCache
        fetchGit

        #fetch updates
        outdated = Pod::Command::Outdated.parse([])
        updates = outdated.public_updates
        updates = updates.select {|subArr| subArr[0] == @name} unless updates.empty?

        if updates.empty?
          UI.puts 'No pod updates are available.'.yellow
        else
          UI.section 'The color indicates what happens when you run `pod update`' do
            UI.puts "#{'<green>'.green}\t - Will be updated to the newest version"
            UI.puts "#{'<blue>'.blue}\t - Will be updated, but not to the newest version because of specified version in Podfile"
            UI.puts "#{'<red>'.red}\t - Will not be updated because of specified version in Podfile"
            UI.puts ''
          end if ansi_output?
          UI.section "The following pod update #{@name} are available:" do
            updates.each do |(name, from_version, matching_version, to_version)|
              color = :blue
              if matching_version == to_version
                color = :green
              elsif from_version == matching_version
                color = :red
              end
              UI.puts "- #{name} #{from_version.to_s.send(color)} -> #{matching_version.to_s.send(color)} " \
              "(latest version #{to_version.to_s})" # rubocop:disable Lint/StringConversionInInterpolation

              unless matching_version.version.empty? || from_version.version.empty?
                if @commit 
                  commit_sha_start = git('rev-parse',from_version).chomp
                  commit_sha_end = git('rev-parse',matching_version).chomp
                  log = git('log','--pretty=format:"%h %s"',"#{commit_sha_start}...#{commit_sha_end}").chomp
                  UI.puts "#{log}" 
                else
                  Dir.chdir(env_git) { 
                    tags = (git! ['tag']).split("\n")                
                    tags.each do |tag|
                      if versionGreat(tag.to_s,from_version.to_s) && versionGreatOrEqual(matching_version.to_s,tag.to_s)
                        commit_sha = git('rev-parse',tag).chomp
                        log = git('log','--pretty=format:"%s"','-n 1',commit_sha).chomp
                        # log = git('show','--quiet','--pretty=format:"%s"',commit_sha)
                        UI.puts "[#{tag}]: ".send(color) + "#{log}"
                      end
                    end
                  } 
                end
              end

            end 
          end
        end
      end

      private
  
      # git command 
      def git(*args)
        Dir.chdir(env_git) { return git! args }
      end

      # env
      def source_pod 
        cat = Pod::Command::Spec::Cat.parse([@name])
        spec = cat.pubulic_spec_and_source_from_spce(@name,false)
        source = spec.attributes_hash['source']['git']
      end

      def env_cache
        File.join(File.expand_path('~/.cache'), 'cocoapods-dist')
      end

      def env_git
        File.join(File.expand_path(env_cache), @name)
      end

      # clone
      def cloneToCache
        unless Dir.exist?(env_git)
          repo_clone(source_pod,env_cache)
        end
      end

      def fetchGit
          Dir.chdir(env_git) { git! ['fetch'] }
      end

      def repo_clone(source, path)
        unless Dir.exist?(path)
          Dir.mkdir(path)
        end
        UI.section("Cloning `#{source}` into `#{path}`.") do
           Dir.chdir(path) { git! ['clone', source] }
        end
      end

      # compare tags (>=)
      def versionGreatOrEqual(tag1, tag2)
        tags1 = tag1.split(".")
        tags2 = tag2.split(".")
      
        # Fill in the missing bits so that both tags have the same number of bits
        max_length = [tags1.length, tags2.length].max
        tags1 += ["0"] * (max_length - tags1.length)
        tags2 += ["0"] * (max_length - tags2.length)
      
        # Compare labels one by one from high to low
        (0...max_length).each do |i|
          if tags1[i].to_i > tags2[i].to_i
            return true
          elsif tags1[i].to_i < tags2[i].to_i
            return false
          end
        end
      
        # If all digits are equal, the labels are considered equal
        return true
      end

      # compare tags （>）
      def versionGreat(tag1, tag2)
        result = versionGreatOrEqual(tag1,tag2)
        if result == true && tag1 == tag2
          return false
        end
        return result
      end
    end
  end
end
