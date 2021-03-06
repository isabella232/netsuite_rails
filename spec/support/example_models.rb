module ExampleModels

  def self.included(example_group)
    example_group.class_eval do
      before do

        define_model :standard_record, email: :string, company: :string, phone: :string, netsuite_id: :integer, is_deleted: :boolean do
          include NetSuiteRails::RecordSync

          netsuite_record_class NetSuite::Records::Customer
          netsuite_sync :read_write
          netsuite_field_map({
            :is_deleted => :is_inactive,
            :phone => :phone,
            :company => Proc.new do |local, netsuite, direction|
              # NOTE this could be done by a simple mapping!
              if direction == :push
                netsuite.company_name = local.company
              else
                local.company = netsuite.company_name
              end
            end
          })
        end

        define_model :custom_record, netsuite_id: :integer, value: :string do
          include NetSuiteRails::RecordSync

          netsuite_record_class NetSuite::Records::CustomRecord, 123
          netsuite_sync :read_write
          netsuite_field_map({
            :custom_field_list => {
              :value => :custrecord_another_value
            }
          })
        end

        define_model :standard_list, netsuite_id: :integer, value: :string do
          include NetSuiteRails::ListSync
          netsuite_list_id 86
        end

        define_model :external_id_record, netsuite_id: :integer, phone: :string do
          include NetSuiteRails::RecordSync

          netsuite_record_class NetSuite::Records::Customer
          netsuite_sync :read_write
          netsuite_field_map({
            :phone => :phone
          })

          def netsuite_external_id
            "phone-#{self.phone}"
          end
        end
      end

      after do
        NetSuiteRails::PollTrigger.instance_variable_set('@record_models', [])
        NetSuiteRails::PollTrigger.instance_variable_set('@list_models', [])
      end

    end
  end
end
