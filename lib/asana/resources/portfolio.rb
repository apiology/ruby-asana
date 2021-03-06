require_relative 'gen/portfolios_base'

module Asana
  module Resources
    # A _portfolio_ gives a high-level overview of the status of multiple
    # initiatives in Asana.  Portfolios provide a dashboard overview of the state
    # of multiple items, including a progress report and the most recent
    # [project status](/developers/api-reference/project_statuses) update.
    #
    # Portfolios have some restrictions on size. Each portfolio has a maximum of 250
    # items and, like projects, a maximum of 20 custom fields.
    class Portfolio < PortfoliosBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :name

      attr_reader :owner

      attr_reader :created_at

      attr_reader :created_by

      attr_reader :custom_field_settings

      attr_reader :color

      attr_reader :workspace

      attr_reader :members

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'portfolios'
        end

        # Creates a new portfolio in the given workspace with the supplied name.
        #
        # Note that portfolios created in the Asana UI may have some state
        # (like the "Priority" custom field) which is automatically added to the
        # portfolio when it is created. Portfolios created via our API will **not**
        # be created with the same initial state to allow integrations to create
        # their own starting state on a portfolio.
        #
        # workspace - [Gid] The workspace or organization in which to create the portfolio.
        # name - [String] The name of the newly-created portfolio
        # color - [String] An optional color for the portfolio
        # options - [Hash] the request I/O options.
        # data - [Hash] the attributes to post.
        def create(client, workspace: required("workspace"), name: required("name"), color: nil, options: {}, **data)
          with_params = data.merge(workspace: workspace, name: name, color: color).reject { |_,v| v.nil? || Array(v).empty? }
          self.new(parse(client.post("/portfolios", body: with_params, options: options)).first, client: client)
        end

        # Returns the complete record for a single portfolio.
        #
        # id - [Gid] The portfolio to get.
        # options - [Hash] the request I/O options.
        def find_by_id(client, id, options: {})

          self.new(parse(client.get("/portfolios/#{id}", options: options)).first, client: client)
        end

        # Returns a list of the portfolios in compact representation that are owned
        # by the current API user.
        #
        # workspace - [Gid] The workspace or organization to filter portfolios on.
        # owner - [String] The user who owns the portfolio. Currently, API users can only get a
        # list of portfolios that they themselves own.
        #
        # per_page - [Integer] the number of records to fetch per page.
        # options - [Hash] the request I/O options.
        def find_all(client, workspace: required("workspace"), owner: required("owner"), per_page: 20, options: {})
          params = { workspace: workspace, owner: owner, limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get("/portfolios", params: params, options: options)), type: self, client: client)
        end
      end

      # An existing portfolio can be updated by making a PUT request on the
      # URL for that portfolio. Only the fields provided in the `data` block will be
      # updated; any unspecified fields will remain unchanged.
      #
      # Returns the complete updated portfolio record.
      #
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def update(options: {}, **data)

        refresh_with(parse(client.put("/portfolios/#{gid}", body: data, options: options)).first)
      end

      # An existing portfolio can be deleted by making a DELETE request
      # on the URL for that portfolio.
      #
      # Returns an empty data record.
      def delete()

        client.delete("/portfolios/#{gid}") && true
      end

      # Get a list of the items in compact form in a portfolio.
      #
      # options - [Hash] the request I/O options.
      def get_items(options: {})

        Collection.new(parse(client.get("/portfolios/#{gid}/items", options: options)), type: Resource, client: client)
      end

      # Add an item to a portfolio.
      #
      # Returns an empty data block.
      #
      # item - [Gid] The item to add to the portfolio.
      # insert_before - [Gid] An id of an item in this portfolio. The new item will be added before the one specified here.
      # `insert_before` and `insert_after` parameters cannot both be specified.
      #
      # insert_after - [Gid] An id of an item in this portfolio. The new item will be added after the one specified here.
      # `insert_before` and `insert_after` parameters cannot both be specified.
      #
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def add_item(item: required("item"), insert_before: nil, insert_after: nil, options: {}, **data)
        with_params = data.merge(item: item, insert_before: insert_before, insert_after: insert_after).reject { |_,v| v.nil? || Array(v).empty? }
        client.post("/portfolios/#{gid}/addItem", body: with_params, options: options) && true
      end

      # Remove an item to a portfolio.
      #
      # Returns an empty data block.
      #
      # item - [Gid] The item to remove from the portfolio.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def remove_item(item: required("item"), options: {}, **data)
        with_params = data.merge(item: item).reject { |_,v| v.nil? || Array(v).empty? }
        client.post("/portfolios/#{gid}/removeItem", body: with_params, options: options) && true
      end

      # Adds the specified list of users as members of the portfolio. Returns the updated portfolio record.
      #
      # members - [Array] An array of user ids.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def add_members(members: required("members"), options: {}, **data)
        with_params = data.merge(members: members).reject { |_,v| v.nil? || Array(v).empty? }
        refresh_with(parse(client.post("/portfolios/#{gid}/addMembers", body: with_params, options: options)).first)
      end

      # Removes the specified list of members from the portfolio. Returns the updated portfolio record.
      #
      # members - [Array] An array of user ids.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def remove_members(members: required("members"), options: {}, **data)
        with_params = data.merge(members: members).reject { |_,v| v.nil? || Array(v).empty? }
        refresh_with(parse(client.post("/portfolios/#{gid}/removeMembers", body: with_params, options: options)).first)
      end

      # Get the custom field settings on a portfolio.
      #
      # options - [Hash] the request I/O options.
      def custom_field_settings(options: {})

        Collection.new(parse(client.get("/portfolios/#{gid}/custom_field_settings", options: options)), type: CustomFieldSetting, client: client)
      end

      # Create a new custom field setting on the portfolio. Returns the full
      # record for the new custom field setting.
      #
      # custom_field - [Gid] The id of the custom field to add to the portfolio.
      # is_important - [Boolean] Whether this field should be considered important to this portfolio (for instance, to display in the list view of items in the portfolio).
      #
      # insert_before - [Gid] An id of a custom field setting on this portfolio. The new custom field setting will be added before this one.
      # `insert_before` and `insert_after` parameters cannot both be specified.
      #
      # insert_after - [Gid] An id of a custom field setting on this portfolio. The new custom field setting will be added after this one.
      # `insert_before` and `insert_after` parameters cannot both be specified.
      #
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def add_custom_field_setting(custom_field: required("custom_field"), is_important: nil, insert_before: nil, insert_after: nil, options: {}, **data)
        with_params = data.merge(custom_field: custom_field, is_important: is_important, insert_before: insert_before, insert_after: insert_after).reject { |_,v| v.nil? || Array(v).empty? }
        Resource.new(parse(client.post("/portfolios/#{gid}/addCustomFieldSetting", body: with_params, options: options)).first, client: client)
      end

      # Remove a custom field setting on the portfolio. Returns an empty data
      # block.
      #
      # custom_field - [Gid] The id of the custom field to remove from this portfolio.
      # options - [Hash] the request I/O options.
      # data - [Hash] the attributes to post.
      def remove_custom_field_setting(custom_field: required("custom_field"), options: {}, **data)
        with_params = data.merge(custom_field: custom_field).reject { |_,v| v.nil? || Array(v).empty? }
        client.post("/portfolios/#{gid}/removeCustomFieldSetting", body: with_params, options: options) && true
      end

    end
  end
end