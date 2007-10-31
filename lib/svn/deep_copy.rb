module SVN

  # convert svn:externals into real paths, esspecially useful for tags when you
  # need to be certain that the tag doesn't change from under you because of an external
  class DeepCopy

    def initialize
    end

    # has the same calling semantics as svn cp, but brings all externals and  preserves as much of the history as possible
    # only when the externals are from remove paths does it lose the history
    def copy( from_svn_path, to_svn_path, extern_info = {} )

      if svn_repository_equal?(from_svn_path, to_svn_path)
        puts "Copying #{from_svn_path} to #{to_svn_path}"
        svn_copy(from_svn_path, to_svn_path)
        puts "Copied #{from_svn_path} to #{to_svn_path}"

        externals = svn_externals(to_svn_path)

        puts "Has externals => #{externals.inspect}"

        # copy each external
        externals.each do|external|
          # svn propdel svn:externals
          svn_propdel( switch_svn_path_base( external[:svn_path], from_svn_path, to_svn_path ), 'svn:externals')

          external[:externals].each do|extern|
            to_path = switch_svn_path_base( extern[:to_path], from_svn_path, to_svn_path )
            from_path = extern[:from_path]
            make_copy( from_path, to_path, extern )
          end
        end
      else
        puts "Remote call!"
        # TODO: support this
        from_url = svn_resolve_to_url(from_svn_path)
        to_url = svn_resolve_to_url(to_svn_path)
        puts extern_info.inspect
        # svn export from_url
        puts("svn export #{from_url} #{from_svn_path}")
        # svn add to_url
        puts("svn import #{from_svn_path} #{to_url}")
        # svn commit to_url
      end

    end

    private

      alias make_copy copy # done so we can mock the recursive calls

      def capture_invoked(cmd)
        `#{cmd}`
      end

      def invoke(cmd)
        system(cmd)
      end

      # switch base paths
      # old_bp => /foo/bar
      # new_bp => /hello/there
      # path => /foo/bar/cool
      # => /hello/there/cool
      def switch_svn_path_base(path,old_base,new_base)
        path.gsub(old_base.gsub(/\/*$/,''),new_base.gsub(/\/*$/,''))
      end

      def svn_propdel(path,prop)
        invoke("svn propdel #{prop} #{path}")
      end

      def svn_repository_equal?(path1,path2)
        svn_info(path1)["repository uuid"] == svn_info(File.dirname(path2))["repository uuid"]
      end

      def svn_resolve_to_url(path)
        if !path.match(/^svn:|^http:/)
          # Make sure we know the svn host of what we're copying so we can save the history for those 
          svn_info(path)["url"]
        else
          path
        end
      end

      def svn_externals(path)
        externals = capture_invoked("svn propget -R svn:externals #{path}")

        base_path = nil
        external_prop = nil
        external_props = []

        externals.each_line do |line|
          line.strip!
          segments = line.split
          if line.match(/ - /)
            base_path = segments.first
            dir_name = base_path + "/" + segments[2]
            svn_path = segments.last
            external_prop = {:svn_path => base_path, :externals => [{:to_path => dir_name , :from_path => svn_path }]}
            external_props  << external_prop
          elsif !line.empty?
            dir_name = base_path + "/" + segments.first
            svn_path = segments.last
            external_prop[:externals] << {:to_path => dir_name , :from_path => svn_path }
          end
        end
        external_props

      end

      def svn_copy(from,to)
        puts "Calling copy #{from} #{to}"
        system("svn copy #{from} #{to} -m 'tagging' ")
      end

      def svn_info(path)
        svn_info = capture_invoked("svn info #{path}")
        info = {}
        return info if svn_info.nil?

        svn_info.split(/\n/).each do|kv|
          kv = kv.split(/: /)
          info[kv[0].downcase] = kv[1]
        end
        info
      end

  end

end
