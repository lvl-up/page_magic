describe PageMagic do
  context '#respond_to?' do
    subject do
      page_class = Class.new do
        include PageMagic
        element :sub_element, id: 'sub-element'
      end
      page_class.new
    end

    it 'checks self' do
      expect(subject.respond_to?(:visit)).to eq(true)
    end

    it 'checks the current page' do
      expect(subject.respond_to?(:sub_element)).to eq(true)
    end
  end
end
