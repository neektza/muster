require 'spec_helper'

describe Muster::Strategies::SortExpression do
  let(:options) { {} }
  subject { Muster::Strategies::SortExpression.new(options) }

  describe '#parse' do

    context 'by default' do
      it 'returns empty hash for empty query string' do
        subject.parse('').should == {}
      end

      it 'returns hash of all key/value pairs' do
        subject.parse('sort=id&order=name').should == { 'sort' => 'id asc', 'order' => 'name asc' }
      end

      it 'hash supports indifferent key access' do
        hash = subject.parse('sort=name')
        hash[:sort].should eq 'name asc'
        hash['sort'].should eq 'name asc'
      end

      it 'combines multiple expressions into an array' do
        subject.parse('sort=id&sort=name').should == { 'sort' => ['id asc', 'name asc'] }
      end

      it 'discards non unique values' do
        subject.parse('sort=id&sort=name&sort=id').should == { 'sort' => ['id asc', 'name asc'] }
      end
    end

    context 'with direction' do
      it 'supports asc' do
        subject.parse('sort=id:asc').should == { 'sort' => 'id asc' }
      end

      it 'supports desc' do
        subject.parse('sort=id:desc').should == { 'sort' => 'id desc' }
      end

      it 'supports ascending' do
        subject.parse('sort=id:ascending').should == { 'sort' => 'id asc' }
      end

      it 'supports desc' do
        subject.parse('sort=id:descending').should == { 'sort' => 'id desc' }
      end
    end

    context 'with :only option' do
      context 'as symbol' do
        before { options[:only] = :sort }

        it 'only returns expressions for the key specified' do
          subject.parse('sort=id&order=name').should == { 'sort' => 'id asc' }
        end
      end

      context 'as Array of symbols' do
        before { options[:only] = [:sort, :order] }

        it 'only returns expressions for the keys specified' do
          subject.parse('sort=id&order=name&direction=place').should == { 'sort' => 'id asc', 'order' => 'name asc' }
        end
      end

      context 'as string' do
        before { options[:only] = 'sort' }

        it 'only returns expressions for the key specified' do
          subject.parse('sort=id&order=name').should == { 'sort' => 'id asc' }
        end
      end

      context 'as Array of strings' do
        before { options[:only] = ['sort', 'order'] }

        it 'only returns expressions for the keys specified' do
          subject.parse('sort=id&order=name&direction=place').should == { 'sort' => 'id asc', 'order' => 'name asc' }
        end
      end
    end

  end
end
