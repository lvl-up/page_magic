# it 'should find by xpath' do
#   element = described_class.new(type: :text_field,
#                                 selector: {xpath: '//div/label/input'}).init(page)
#
# end
#
# it 'should locate an element using its id' do
#   element = described_class.new(type: :text_field,
#                                 selector: {id: 'field_id'}).init(page)
#   expect(element.value).to eq('filled in')
# end
#
# it 'should locate an element using its name' do
#   element = described_class.new(type: :text_field,
#                                 selector: {name: 'field_name'}).init(page)
#   expect(element.value).to eq('filled in')
# end
#
# it 'should locate an element using its label' do
#   element = described_class.new(type: :text_field,
#                                 selector: {label: 'enter text'}).init(page)
#   expect(element[:id]).to eq('field_id')
# end
#
# it 'should locate an element using css' do
#   element = described_class.new(type: :text_field,
#                                 selector: {css: "input[name='field_name']"}).init(page)
#   expect(element[:id]).to eq('field_id')
# end
#
# it 'should return a prefetched value' do
#   element = described_class.new(type: :link, prefetched_browser_element: :prefetched_object)
#   expect(element.init(page)).to eq(:prefetched_object)
# end
#
# it 'should raise errors for unsupported criteria' do
#   element = described_class.new(type: :link,
#                                 selector: {unsupported: ''})
#
#   expect { element.init(page) }.to raise_error(PageMagic::UnsupportedCriteriaException)
# end
#
# context 'text selector' do
#   it 'should locate a link' do
#     element = described_class.new(type: :link,
#                                   selector: {text: 'link in a form'}).init(page)
#     expect(element[:id]).to eq('form_link')
#   end
#
#   it 'should locate a button' do
#     element = described_class.new(type: :button, selector: {text: 'a button'}).init(page)
#     expect(element[:id]).to eq('form_button')
#   end
# end
