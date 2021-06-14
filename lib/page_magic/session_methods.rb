# frozen_string_literal: true

require 'forwardable'
module PageMagic
  # module SessionMethods - contains methods for interacting with the {Session}
  module SessionMethods
    extend Forwardable

    # @!method execute_script(script)
    #  execute javascript on the browser
    #  @param [String] script the script to be executed
    #  @return [Object] object returned by the {Session#execute_script}
    def_delegator :session, :execute_script

    # @!method page
    #  returns the currently active page object
    #  @see Session#current_page
    def_delegator :session, :current_page, :page

    # @!method path
    #  returns the current path
    #  @see Session#current_path
    def_delegator :session, :current_path, :path

    # @!method url
    #  returns the current url
    #  @see Session#current_url
    def_delegator :session, :current_url, :url
  end
end
