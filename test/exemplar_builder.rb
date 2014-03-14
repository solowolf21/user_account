module ExemplarBuilder

  def exemplify(klass, *args, &block)
    @@counter_hash ||= {}

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
            @@counter_hash[klass] ||= 0
            exemplar_count = "#{$$}#{@@counter_hash[klass] += 1}".to_i
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
          @@counter_hash[klass] ||= 0
          exemplar_count = "#{$$}#{@@counter_hash[klass] += 1}".to_i
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
