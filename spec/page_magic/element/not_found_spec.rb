describe PageMagic::Element::NotFound do
  describe '#method_missing' do
    it 'raises an error' do
      subject = described_class.new(Exception.new('message'))
      expect{subject.any_missing_method}.to raise_exception(PageMagic::ElementMissingException, 'message')
    end
  end

  describe '#visible?' do
    it 'returns false' do
      subject = described_class.new(Exception.new('message'))
      expect(subject.visible?).to eq(false)
    end
  end

  describe '#present?' do
    it 'returns false' do
      subject = described_class.new(Exception.new('message'))
      expect(subject.present?).to eq(false)
    end
  end
end
