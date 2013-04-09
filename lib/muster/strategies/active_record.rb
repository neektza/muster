require 'active_support/core_ext/array/wrap'
require 'active_support/hash_with_indifferent_access'
require 'muster/strategies/hash'
require 'muster/results'
require 'muster/strategies/filter_expression'
require 'muster/strategies/sort_expression'
require 'muster/strategies/joins_expression'
require 'muster/strategies/pagination'

module Muster
  module Strategies
    class ActiveRecord < Muster::Strategies::Rack

      def parse( query_string )
        pagination = self.parse_pagination( query_string )

        parameters = Muster::Results.new(
          :select   => self.parse_select(query_string),
          :group    => self.parse_group(query_string),
          :order    => self.parse_order(query_string),
          :where    => self.parse_where(query_string),
          :joins    => self.parse_joins(query_string),
          :includes => self.parse_includes(query_string),
          :limit    => pagination[:limit] || 50,
          :offset   => pagination[:offset],
          :count    => self.parse_count(query_string)
        )

        return parameters
      end

      protected

      def parse_select( query_string )
        strategy = Muster::Strategies::Hash.new(:field => :select)
        results  = strategy.parse(query_string)

        return Array.wrap( results[:select] )
      end
      
      def parse_group( query_string )
        strategy = Muster::Strategies::Hash.new(:field => :group)
        results  = strategy.parse(query_string)

        return results[:group]
      end

      def parse_order( query_string )
        strategy = Muster::Strategies::SortExpression.new(:field => :order)
        results  = strategy.parse(query_string)

        return Array.wrap( results[:order] )
      end


      def parse_where( query_string )
        strategy = Muster::Strategies::FilterExpression.new(:field => :where)
        results  = strategy.parse(query_string)

        return results[:where] || {}
      end

      def parse_joins( query_string )
        strategy = Muster::Strategies::JoinsExpression.new(:field => :joins)
        results  = strategy.parse(query_string)

        return results[:joins] || {}
      end
      
      def parse_includes( query_string )
        strategy = Muster::Strategies::JoinsExpression.new(:field => :includes)
        results  = strategy.parse(query_string)

        return results[:includes] || {}
      end
      
      def parse_pagination( query_string )
        strategy = Muster::Strategies::Hash.new(:fields => [:limit, :offset])
        results  = strategy.parse(query_string)
        
        return results
      end

      def parse_count( query_string )
        strategy = Muster::Strategies::Hash.new(:field => :count)
        results  = strategy.parse(query_string)

        return results[:count]
      end

    end
  end
end
