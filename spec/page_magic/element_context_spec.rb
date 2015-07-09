describe PageMagic::ElementContext do

  include_context :webapp

  let!(:page1) do
    Class.new do
      include PageMagic
      url '/page1'
      link(:next, :text => "next page")
    end
  end

  let!(:elements_page) do
    Class.new do
      include PageMagic
      url '/elements'
      link(:a_link, :text => "a link")
    end
  end

  let!(:session) do
    double('session', raw_session: double('browser'))
  end

  describe 'resolving field definitions' do

    it 'should only evaluate the targeted field definition' do
      page1.class_eval do
        link(:link, :selector) do
          fail("should not have been evaluated")
        end
      end
      page = page1.new
      page.visit

      described_class.new(page, page.browser, self).next
    end
  end

  it 'should raise an error if an element is not found' do
    expect { described_class.new(page1.new(session), session, self).missing_thing }.to raise_error PageMagic::ElementMissingException
  end

  it 'should attempt to execute method on page object it is defined' do
    page1.class_eval do
      def page_method
        :called
      end
    end

    described_class.new(page1.new(session), session, self).page_method.should == :called
  end

  describe 'retrieving elements' do
    it 'should give the capybara object' do
      page = elements_page.new
      page.visit

      element = described_class.new(page, page.browser, self).a_link
      element.text.should == 'a link'
    end
  end

  describe 'accessing page sections' do
    it 'should go through page sections' do

      elements_page.class_eval do
        section :form do
          selector css: '.form'
          link :form_link, text: 'in a form'
        end
      end

      page = elements_page.new
      page.visit

      described_class.new(page, page.browser, self).form
    end


    it 'should delegate to page element if method not found' do
      #TODO call page method, look for subelement, delagate to capybara object
    end
  end



  describe 'hooks' do

    subject(:page) do
      elements_page.new.tap do|p|
        p.visit
      end
    end

    before do
      browser = page.browser
      browser.should_receive(:call_in_before_hook)
      browser.should_receive(:call_in_after_before_hook)
    end


    context 'section' do
      it 'applies the hooks' do

        elements_page.section(:form, id: 'form') do
          link :form_link, id: 'form_link'

          before do |page_browser|
            page_browser.call_in_before_hook
          end

          after do |page_browser|
            page_browser.call_in_after_before_hook
          end
        end

        described_class.new(page, page.browser, self).form.click
      end
    end

    it 'should execute a before and after action that gives access to the browser' do
      elements_page.link(:create, text: 'a link') do
        before do |page_browser|
          page_browser.call_in_before_hook
        end

        after do |page_browser|
          page_browser.call_in_after_before_hook
        end
      end

      described_class.new(page, page.browser, self).create.click
    end

  end

end
