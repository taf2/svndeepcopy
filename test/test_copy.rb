require File.join(File.dirname(__FILE__), 'helper')

class TestCopy < Test::Unit::TestCase
  
  def setup
    @copier = SVN::DeepCopy.new
  end

  def test_svn_externals_from_remote_path
    @copier.expects(:capture_invoked).returns(load_fixture('sample_remote.fixture'))
    externals = @copier.send(:svn_externals,"https://source.revolutionhealth.com/svn/rhg/services/ruby//groups_service/trunk/")
    assert_equal 4, externals.size
    total = 0
    externals.each do|external|
      total += external[:externals].size
    end
    assert_equal 13, total
    assert_equal eval(load_fixture("sample_remote.external")), externals
  end

  def test_svn_externals_from_local_path
    @copier.expects(:capture_invoked).returns(load_fixture('sample_local.fixture'))
    externals = @copier.send(:svn_externals,"/home/taf2/rhg/services/ruby/groups_service/trunk/")
    assert_equal 4, externals.size
    total = 0
    externals.each do|external|
      total += external[:externals].size
    end
    assert_equal 13, total
    assert_equal eval(load_fixture("sample_local.external")), externals
  end

  def test_base_path_switch
    assert_equal "/hello/there/cool", @copier.send(:switch_svn_path_base,"/foo/bar/cool","/foo/bar","/hello/there")
    assert_equal "/hello/there/cool", @copier.send(:switch_svn_path_base,"/foo/bar/cool","/foo/bar/","/hello/there/")
    assert_equal "http://hello/there/cool", @copier.send(:switch_svn_path_base,"http://foo/bar/cool","http://foo/bar///","http://hello/there//")
  end

  def test_copy_sample_repo
    @copier.expects(:capture_invoked).returns("").times(13)
    @copier.expects(:capture_invoked).returns(load_fixture("sample_remote.fixture")).at_most_once
    @copier.expects(:svn_propdel).returns(nil).times(4)
    @copier.stubs(:svn_copy).returns(nil)
    @copier.stubs(:svn_info).returns(load_fixture("info.fixture"))
    @copier.copy("https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/trunk/",
                 "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit")
  end
  
  def test_copy_correct_externals
    repo_path = "https://source.revolutionhealth.com/svn/rhg"
    @copier.expects(:capture_invoked).returns(load_fixture("sample_remote.fixture")).at_most_once
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/app",                        "#{repo_path}/services/ruby/groups_service/branches/testit/app").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/db",                         "#{repo_path}/services/ruby/groups_service/branches/testit/db").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/doc",                        "#{repo_path}/services/ruby/groups_service/branches/testit/doc").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/lang",                       "#{repo_path}/services/ruby/groups_service/branches/testit/lang").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/lib",                        "#{repo_path}/services/ruby/groups_service/branches/testit/lib").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/log",                        "#{repo_path}/services/ruby/groups_service/branches/testit/log").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/public-service",             "#{repo_path}/services/ruby/groups_service/branches/testit/public").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/script",                     "#{repo_path}/services/ruby/groups_service/branches/testit/script").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/tmp",                        "#{repo_path}/services/ruby/groups_service/branches/testit/tmp").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/vendor",                     "#{repo_path}/services/ruby/groups_service/branches/testit/vendor").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/test/functional/services",   "#{repo_path}/services/ruby/groups_service/branches/testit/test/functional/services").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/test/integration/services",  "#{repo_path}/services/ruby/groups_service/branches/testit/test/integration/services").returns(nil)
    @copier.expects(:make_copy).with("#{repo_path}/applications/ruby/groups/trunk/test/fixtures",              "#{repo_path}/services/ruby/groups_service/branches/testit/test/fixtures").returns(nil)
    @copier.stubs(:svn_copy).returns(nil)
    @copier.expects(:svn_propdel).with("#{repo_path}/services/ruby/groups_service/branches/testit", "svn:externals").returns(0)
    @copier.expects(:svn_propdel).with("#{repo_path}/services/ruby/groups_service/branches/testit/test/functional", "svn:externals").returns(0)
    @copier.expects(:svn_propdel).with("#{repo_path}/services/ruby/groups_service/branches/testit/test/integration", "svn:externals").returns(0)
    @copier.expects(:svn_propdel).with("#{repo_path}/services/ruby/groups_service/branches/testit/test", "svn:externals").returns(0)
    @copier.stubs(:svn_info).returns(load_fixture("info.fixture"))
    @copier.copy("#{repo_path}/services/ruby/groups_service/trunk/",
                 "#{repo_path}/services/ruby/groups_service/branches/testit")
  end

  def test_copy_with_outside_repo
    repo_path = "https://source.revolutionhealth.com/svn/rhg"
    @copier.stubs(:svn_copy).returns(nil)
    @copier.expects(:capture_invoked).with("svn propget -R svn:externals #{repo_path}/applications/ruby/newsletters/branches/testit").returns(load_fixture("sample2_remote.fixture"))
    @copier.expects(:capture_invoked).with("svn info #{repo_path}/applications/ruby/newsletters/trunk/").times(1).returns(load_fixture("info.fixture"))
    @copier.expects(:capture_invoked).with("svn info #{repo_path}/applications/ruby/newsletters/branches/testit").times(1).returns(load_fixture("info.fixture"))
    @copier.expects(:capture_invoked).with("svn info #{repo_path}/applications/ruby/newsletters/branches/testit/vendor/plugins/mocha").times(2).returns(nil)
    @copier.expects(:capture_invoked).with("svn info #{repo_path}/applications/ruby/newsletters/branches/testit/vendor/plugins/rails_rcov").times(2).returns(nil)
    @copier.expects(:capture_invoked).with("svn info #{repo_path}/portal/content/trunk/test/fixtures/content").times(2).returns(load_fixture("info.fixture"))
    @copier.expects(:capture_invoked).with("svn info #{repo_path}/applications/ruby/newsletters/branches/testit/test/fixtures/content").times(2).returns(nil)

    @copier.expects(:capture_invoked).with("svn info http://svn.codahale.com/rails_rcov").returns(load_fixture("rails_rcov_info.fixture"))
    @copier.expects(:capture_invoked).with("svn info svn://rubyforge.org/var/svn/mocha/trunk").returns(load_fixture("mocha_info.fixture"))

    @copier.expects(:svn_propdel).with("#{repo_path}/applications/ruby/newsletters/branches/testit/vendor/plugins",
                                       "svn:externals").returns(0)
    
    @copier.expects(:svn_propdel).with("#{repo_path}/applications/ruby/newsletters/branches/testit/test/fixtures",
                                       "svn:externals").returns(0)
 
    @copier.copy("#{repo_path}/applications/ruby/newsletters/trunk/",
                 "#{repo_path}/applications/ruby/newsletters/branches/testit")
  end

  def load_fixture(name)
    File.read(File.join(File.dirname(__FILE__), name))
  end

end
