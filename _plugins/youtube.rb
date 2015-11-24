module Jekyll
  class Youtube < Liquid::Tag

    def initialize(name, markup, tokens)
        if markup =~ /(\S+) (\d+) (\d+)/i
            @id = $1
            @width = $2
            @height = $3
        else
            @id = markup
            @width = 480
            @height = 360
        end
        super
    end

    def render(context)
      @div_width = @width.to_i + 20
      @div_height = @height.to_i + 15
      %(<div style="width:#{@div_width}px;height:#{@div_height}px;margin-bottom:20px"><iframe width="#{@width}" height="#{@height}" src="http://www.youtube.com/embed/#{@id}" frameborder="0" allowfullscreen> </iframe></div>)
    end
  end
end

Liquid::Template.register_tag('youtube', Jekyll::Youtube)