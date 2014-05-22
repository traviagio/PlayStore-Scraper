require 'rubygems'
require 'mechanize'
require 'pp'
require 'json'

agent = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
}


@apps = Hash.new


def process_link app_link
    begin
        app = app_link.click
        title = app.search('.document-title')
        subtitle = app.search('.primary')
        category = app.search('.category')
        id = app_link.href[/\=(.*)/]
        if category.text.strip.downcase == "education" && !@apps.has_key?(id)
            score = app.search('.score')
            email = app.link_with(:text => "Email Developer")
            devSite = app.link_with(:text => "Visit Developer's Website")

            company = Hash.new
            company[:title] = title.text.strip
            company[:subtitle] = subtitle.text.strip
            company[:score] = score.text.strip
            company[:email] = email.href.strip
            company[:site] = devSite.href.strip

            @apps[id] = company

            File.open('gfree2.json', 'a') do |f|
                f.write(company.to_json)
            end

            # Through all the similar links
            similar_links = app.search(".card-click-target")
            similar_links.each do |link|
                process_link link.xpath("@href").text.strip
            end
                # process_link link
            # end
        else
            p "This is not an education app or i have already done this app"
            return
        end
    rescue
    end
end



page = agent.get('http://localhost:8000/top_free.html')

page_links = []
page.links.each do |link|
      cls = link.attributes.attributes['class']
      page_links << link if cls && cls.value == 'title'
end
page_links.each do |app_link|
    process_link app_link
end





puts apps.to_json
