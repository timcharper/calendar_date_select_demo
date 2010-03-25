# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def eval_and_show_code(code)
    <<-EOF
<p>
  #{eval(code)}
</p>
<pre>
&lt;%= #{h code.strip.gsub("\n", "\n    ") } %&gt;
</pre>
    EOF
  end
end
