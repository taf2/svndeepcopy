svn cp from\_path to\_path

Does not copy the externals.  Very often projects will have externals to a trunk and use svn copy to create a tag.  The obvious problem with this is when you make that tag it's not going to be the same tomorrow when that externals trunk gains new features and potentially changes it interface.  svn deep copy is a script to automatically copy the path and all it's externals.