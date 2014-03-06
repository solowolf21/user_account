module ExemplarBuilder

  def exemplify(klass, *args, &block)
    options = {}
    if ! args.first.is_a? Hash
      options[:method] = args.first
    else
      options = args.first
    end

    namespace = options.has_key?( :namespace ) ? "#{options[:namespace]}_" : ""
    method = options[:method]

    count_var_name = "#{klass.to_s.underscore.gsub(/\//, '_')}_#{namespace}exemplar_count"

    exemplar_method = "#{namespace}exemplar"

    if method
      klass.instance_eval do
        define_method("#{method}_exemplar".to_sym) do |*params|
          overrides = params.first
          overrides ||= {}

          self.tap do |new_exemplar|
            exemplar_count = Rails.cache.increment(count_var_name, 1, :namespace => "af_rails_exemplars")
            block.call(new_exemplar, exemplar_count, overrides) if block
            new_exemplar.assign_attributes(overrides)
            save! unless new_record?
          end
        end
      end

    else
      (class << klass; self; end).class_eval do
        define_method( exemplar_method ) do |*params|
          overrides = params.first
          overrides ||= {}

          exemplar_count = Rails.cache.increment(count_var_name, 1, :namespace => "af_rails_exemplars")
          Rails.logger.info("exemplar_builder: #{count_var_name} #{exemplar_count}")

          klass.new.tap do |new_exemplar|
            block.call(new_exemplar, exemplar_count, overrides) if block
            new_exemplar.assign_attributes(overrides)
          end
        end

        define_method("#{namespace}create_exemplar") do |*params|
          overrides = params.first
          perform_validation = true
          if overrides && overrides.has_key?(:perform_validation)
            perform_validation = !!overrides.delete(:perform_validation)
          end
          send( exemplar_method, overrides ).tap {|e| e.save!(:validate => perform_validation) }
        end

        define_method("#{namespace}create_exemplar!") do |*params|
          send( exemplar_method, *params ).tap {|e|
            begin
              e.save!
            rescue ActiveRecord::RecordInvalid => e
              Rails.logger.info("exemplar_method: count in the db #{klass.count}")
              raise
            end
          }
        end
      end
    end
  end
end
