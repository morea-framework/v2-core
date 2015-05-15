module Jekyll
  class MoreaUrlTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      @text = text
    end

    def render(context)
      @site = context.registers[:site]
      @page = @site.config['morea_page_table'][@text]
      @url = "undefined ID"
      if page
        @url = page.url
      end

      "#{url}"
    end
  end
end

Liquid::Template.register_tag('morea_url', Jekyll::MoreaUrlTag)