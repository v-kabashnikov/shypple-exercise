# frozen_string_literal: true

module Sailings
  class RouteFinder < BaseService
    parameters do
      required(:sailings).filled(:array)
      required(:origin_port).filled(:string)
      required(:destination_port).filled(:string)
      optional(:max_legs).maybe(:integer)
    end

    def call
      graph = build_graph(params[:sailings])
      routes = find_routes(graph, params[:origin_port], params[:destination_port], params[:max_legs])
      Success(routes)
    end

    private

    def build_graph(sailings)
      graph = {}
      sailings.each do |sailing|
        origin = sailing['origin_port']
        destination = sailing['destination_port']
        graph[origin] ||= {}
        graph[origin][destination] ||= []
        graph[origin][destination] << sailing
      end
      graph
    end

    def find_routes(graph, from, to, max_legs)
      if max_legs == 1
        single_leg_routes(graph, from, to)
      else
        find_all_routes(graph, from, to)
      end
    end

    def single_leg_routes(graph, from, to)
      # Return direct routes between from and to
      [graph[from][to]].compact.flatten.map { |sailing| [sailing] }
    end

    def find_all_routes(graph, from, to)
      all_routes = []
      dfs(graph, from, to, [], all_routes)
      all_routes.map { |route| route.flatten(1) } # Flatten each route one level deep
    end

    def dfs(graph, current, destination, path, all_routes, last_arrival_date = nil)
      return if path.any? { |p| p['origin_port'] == current } # Avoid cycles

      graph[current]&.each do |next_port, sailings|
        sailings.each do |sailing|
          next if last_arrival_date && sailing['departure_date'] < last_arrival_date
          next if path.any? { |p| p['sailing_code'] == sailing['sailing_code'] } # Avoid using the same sailing twice

          if next_port == destination
            all_routes << (path + [sailing]) if path.empty? || sailing['departure_date'] >= path.last['arrival_date']
          else
            dfs(graph, next_port, destination, path + [sailing], all_routes, sailing['arrival_date'])
          end
        end
      end
    end
  end
end
