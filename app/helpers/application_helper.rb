module ApplicationHelper

  def markdown(text)
    renderer = Redcarpet::Render::HTML.new()
    options = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_spacing: true,
      strikethrough: true,
      superscript: true,
    }
    Redcarpet::Markdown.new(renderer, options).render(text)
  end

end
