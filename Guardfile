# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'ctags-bundler', src_path: ['.', 'app', 'lib', 'spec/support'], stdlib: true do
  watch(/^(app|lib|spec\/support)\/.*\.rb$/)
  watch(/^*.rb$/)
  watch('Gemfile.lock')
end
