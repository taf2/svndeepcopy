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
    @copier.expects(:capture_invoked).returns(load_fixture("sample_remote.fixture")).at_most_once
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/app", "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/app").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/db",                         "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/db").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/doc",                        "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/doc").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/lang",                       "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/lang").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/lib",                        "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/lib").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/log",                        "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/log").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/public-service",             "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/public").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/script",                     "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/script").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/tmp",                        "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/tmp").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/vendor",                     "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/vendor").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/test/functional/services",   "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/test/functional/services").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/test/integration/services",  "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/test/integration/services").returns(nil)
    @copier.expects(:make_copy).with("https://source.revolutionhealth.com/svn/rhg/applications/ruby/groups/trunk/test/fixtures",              "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/test/fixtures").returns(nil)
    @copier.stubs(:svn_copy).returns(nil)
    @copier.expects(:svn_propdel).with("https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit", "svn:externals").returns(0)
    @copier.expects(:svn_propdel).with("https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/test/functional", "svn:externals").returns(0)
    @copier.expects(:svn_propdel).with("https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/test/integration", "svn:externals").returns(0)
    @copier.expects(:svn_propdel).with("https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit/test", "svn:externals").returns(0)
    @copier.stubs(:svn_info).returns(load_fixture("info.fixture"))
    @copier.copy("https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/trunk/",
                 "https://source.revolutionhealth.com/svn/rhg/services/ruby/groups_service/branches/testit")
  end

  def test_base_path_switch
    assert_equal "/hello/there/cool", @copier.send(:switch_svn_path_base,"/foo/bar/cool","/foo/bar","/hello/there")
    assert_equal "/hello/there/cool", @copier.send(:switch_svn_path_base,"/foo/bar/cool","/foo/bar/","/hello/there/")
    assert_equal "/hello/there/cool", @copier.send(:switch_svn_path_base,"/foo/bar/cool","/foo/bar///","/hello/there//")
  end

  def load_fixture(name)
    File.read(File.join(File.dirname(__FILE__), name))
  end

end
