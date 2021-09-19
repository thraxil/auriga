defmodule AlchemistMarkdown do
  def to_html(markdown \\ "", opts \\ [])

  def to_html(markdown, _opts) do
    markdown
    |> hrs
    |> divs
    |> Earmark.as_html!(earmark_options())
    |> HtmlSanitizeEx.html5()
    |> smalls
    |> bigs
  end

  # for now, we'll just replace H1 and H2 tags with H3s, but as the site grows and it becomes necessary, we'll add more restrictions to commenters. 
  def to_commenter_html(markdown) do
    to_html(markdown)
    |> h3_is_max
  end

  # Earmark doesn't support adding CSS classes to divs yet
  def divs(text) do
    matcher = ~r{(^|\n)::div((\.[\w-]*)*) ?(.*?)(\n):/div ?}s
    matches = Regex.run(matcher, text)

    case matches do
      nil ->
        text

      [matched_part, _, classes, _, inner_md | _tail] ->
        classname = classes |> String.split(".", trim: true) |> Enum.join(" ")
        html = "<div class=#{classname}>#{to_html(inner_md)}</div>"
        String.replace(text, matched_part, html)
    end
  end

  def bigs(text) do
    replace_unless_pre(text, ~r/\+\+(.+)\+\+/, "<big>\\1</big>")
  end

  def hrs(text) do
    Regex.replace(~r{(^|\n)([-*])( *\2 *)+\2}s, text, "\\1<hr />")
  end

  def h3_is_max(text) do
    text = Regex.replace(~r{<h1([^<]*>(.*)<\/)h1>}s, text, "<h3\\1h3>")
    Regex.replace(~r{<h2([^<]*>(.*)<\/)h2>}s, text, "<h3\\1h3>")
  end

  # Replace the input text based on the regex and replacement text provided
  # ... except leave everything inside <pre> blocks as is
  def replace_unless_pre(text, rexp, replacement) do
    Regex.split(~r|<pre[^<]*>.*<\/pre>|s, text, include_captures: true)
    |> Enum.map(fn str ->
      case String.starts_with?(str, "<pre") do
        true -> str
        _ -> Regex.replace(rexp, str, replacement)
      end
    end)
    |> Enum.join("")
  end

  def smalls(text) do
    replace_unless_pre(text, ~r/--(.+)--/, "<small>\\1</small>")
  end

  defp earmark_options() do
    %Earmark.Options{
      code_class_prefix: "lang-",
      smartypants: false
    }
  end
end
