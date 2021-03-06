require_relative 'gen/project_memberships_base'

module Asana
  module Resources
    # With the introduction of "comment-only" projects in Asana, a user's membership
    # in a project comes with associated permissions. These permissions (whether a
    # user has full access to the project or comment-only access) are accessible
    # through the project memberships endpoints described here.
    class ProjectMembership < ProjectMembershipsBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :user

      attr_reader :project

      attr_reader :write_access

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'project_memberships'
        end

        # Returns the compact project membership records for the project.
        #
        # project - [Gid] The project for which to fetch memberships.
        # user - [String] If present, the user to filter the memberships to.
        # per_page - [Integer] the number of records to fetch per page.
        # options - [Hash] the request I/O options.
        def find_by_project(client, project: required("project"), user: nil, per_page: 20, options: {})
          params = { user: user, limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get("/projects/#{project}/project_memberships", params: params, options: options)), type: Resource, client: client)
        end
        alias_method :get_many, :find_by_project

        # Returns the project membership record.
        #
        # id - [Gid] Globally unique identifier for the project membership.
        #
        # options - [Hash] the request I/O options.
        def find_by_id(client, id, options: {})

          self.new(parse(client.get("/project_memberships/#{id}", options: options)).first, client: client)
        end
        alias_method :get_single, :find_by_id
      end

    end
  end
end
