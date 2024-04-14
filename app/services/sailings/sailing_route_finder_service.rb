# frozen_string_literal: true

class Sailings::SailingRouteFinderService < BaseService
  def initialize(sailings)
    @graph = build_graph(sailings)
  end

  def find_route(from, to, max_legs: nil)
    if max_legs == 1
      [@graph[from][to]].compact.flatten.map { |sailing| [sailing] }
    else
      find_all_routes(from, to)
    end
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

  def find_all_routes(from, to)
    all_routes = []
    dfs(from, to, [], all_routes)
    all_routes.map { |route| route.flatten(1) } # Flatten each route one level deep
  end

  def dfs(current, destination, path, all_routes, last_arrival_date = nil)
    return if path.any? { |p| p['origin_port'] == current } # Avoid cycles

    # If there is a last arrival date, we make sure not to consider sailings before that date
    @graph[current]&.each do |next_port, sailings|
      sailings.each do |sailing|
        next if last_arrival_date && sailing['departure_date'] < last_arrival_date
        next if path.any? { |p| p['sailing_code'] == sailing['sailing_code'] } # Avoid using the same sailing twice

        if next_port == destination
          all_routes << (path + [sailing]) if path.empty? || sailing['departure_date'] >= path.last['arrival_date']
        else
          dfs(next_port, destination, path + [sailing], all_routes, sailing['arrival_date'])
        end
      end
    end
  end
end
