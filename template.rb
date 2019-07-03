####################################################################
require 'oga'
require 'pp'
####################################################################

module Oga

  def self.transform(doc, template)
    results = {}

    template.each do |field, query|
      case query
      when String
        result = doc.xpath(query)
        results[field] = result.is_a?(Oga::XML::NodeSet) ? result.first.text : result
      when Array
        array_query, sub_template = query
        nodes = doc.xpath(array_query)
        array_result = nodes.map do |node|
          transform(node, sub_template)
        end
        results[field] = array_result
      else
        raise "wtf? a #{query.class}?"
      end
    end

    results
  end
   
  class XML::Document
    def transform(template)
      Oga.transform(self, template)
    end
  end
   
  class HTML::Document
    def transform(template)
      Oga.transform(self, template)
    end
  end

end

template = {
  results: ['//*[@class="module_row"]', {
    name:        './/a[@class="title"]',
    path:        './/a[@class="title"]/@href',
    downloads:   "number(.//*[@class='downloads']/*[@class='value'])",
    author:      ".//span[@class='author']/a",
    description: "*[@class='summary']",
  }],
  query: "//div[@class='search_page']//input[@name='q']/@value"
}

doc = Oga.parse_html open("luarocks.html")
results = doc.transform(template)

puts
pp results
