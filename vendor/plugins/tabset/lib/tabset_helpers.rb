module TabsetHelpers
  def tabset(options={}, &block)
    # set a default id
    options[:uniq_id]||= "tabset_div_" + (  $tabset_unique_id = ($tabset_unique_id||0) + 1 ).to_s
    uniq_id = options.delete(:uniq_id)
    if options.has_key?(:selected)
      selected_tab = options.delete(:selected) || ""
    end
     
    @tabset_tabs=[]
    
    tabs_content = capture(&block)
    
    tabs_html = ""
    
    # output the tabs
    @tabset_tabs.each { | tab |
      tabs_html << "<li id='#{tab[:id]}_tab_button'><a href=\"javascript:$('#{uniq_id}').tabset.gotab('#{tab[:id]}');\"><span>#{tab[:label]}</span></a></li>"
    }
    
    tabs_html = content_tag(
      :div, 
      content_tag(
        :ul, 
        tabs_html),
      options
      
    )
        
    tablist=@tabset_tabs.collect{|tab| '"' + tab[:id].to_s + '"'} * ', '
    
    # output the javascript
    js_output = <<END_OF_STRING

      Tabset = Class.create();
      Tabset.prototype = {
        initialize: function(base_element_id, tablist)
        {
          this.tab_elements=$H();
          this.master_parent = null;
          this.base_element = $(base_element_id); 
          this.base_element.tabset = this; // create a self-reference
          that=this;
          $A(tablist).each(function(tab) {
            tab_element = that.$(tab + '_tab');
            that.tab_elements.set(tab, tab_element);
            that.master_parent = tab_element.parentNode;
          });
        },
        $$: function(selector)
        {
          return this.base_element.getElementsBySelector(selector);
        },
        $: function(id)
        {
          return this.base_element.getElementsBySelector("#" + id).first();
        },
        gotab: function(tab_name)
        {
          if (! this.tab_elements.get(tab_name)) return false;
          
          that=this;
          $A(this.master_parent.childNodes).each(function(node) {
            Element.remove(node);
          });
          
          this.tab_elements.each(function(pair) {
            that.$(pair.key + '_tab_button').className="";
          });
          
          this.$(tab_name + '_tab_button').className="current";
          
          this.tab_elements.each(function(hash_index) {
            tab_element = hash_index.value;
            
            if (hash_index.key == tab_name)
            {
              tab_element.style.display = "";
              
              that.master_parent.appendChild(tab_element);
            }
            else
              that.$('tab_element_storage').appendChild(tab_element);
          });
        }
      }
    
    new Tabset("#{uniq_id}", [#{tablist}]);
    
END_OF_STRING
    
    selected_tab||= @tabset_tabs.first[:id]
    js_output << "$('#{uniq_id}').tabset.gotab('#{selected_tab}');"

    concat("<div id='#{uniq_id}'>")
    concat(tabs_html)
    concat("<div>")
    concat(tabs_content)
    concat("</div>")
    # Create a place for the tabs to be stored, temporarily
    concat("<div id='tab_element_storage' style='position:absolute; display:none;'></div>")
    
    # Output all of the necessary javascript
    concat("<script language='javascript'>#{js_output}</script>")
    concat("</div>")
  end
  
  def define_tab(id, label, &block)
    @tabset_tabs << {
      :id => id,
      :label => label
    }
    
    concat("<div id='#{id}_tab' style='display:none'>")
    concat(capture(&block))
    concat("</div>")
  end

end