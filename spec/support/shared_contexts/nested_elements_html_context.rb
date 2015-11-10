shared_context :nested_elements_html do
  require 'sinatra/base'

  let(:nested_elements_html) do
    <<-HTML
      <div id="parent">
        <div id="child">
        </div>
      </div>
    HTML
  end

  let(:nested_elements_node) do
    Capybara::Node::Simple.new(nested_elements_html)
  end

end
