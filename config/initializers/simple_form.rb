SimpleForm.setup do |config|
  config.wrappers :row, :class => 'row', :error_class => 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.use :label
    b.use :input_with_errors, :wrap_with => { :tag => 'span', :class => 'field_with_errors' }
    b.use :error, :wrap_with => { :tag => 'span', :class => 'help-inline' }
  end

  config.browser_validations = false
end