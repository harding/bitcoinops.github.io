# frozen_string_literal: true

# Regex pattern to match "{% assign timestamp="xx:xx:xx" %}"
$podcast_reference_mark = /\{%\s*assign\s+timestamp\s*=\s*"([^"]+)"\s*%\}/

# Create the podcast recap references by parsing the referenced newsletter for
# podcast reference marks (timestamps)
class RecapReferencesGenerator < Jekyll::Generator
  def generate(site)
    podcast_pages = site.documents.select { |doc| doc.data["type"] == "podcast"}
    podcast_pages.each do |podcast|
      # podcast episodes have a "reference" field that indicates the related newsletter page 
      unless podcast.data["reference"].nil?
        reference_page = site.documents.detect { |page| page.url == podcast.data["reference"] }
        
        # override the content of the reference page (newsletter) to now include
        # the links to the related podcast items
        reference_page.content,
        # keep all the references in a podcast page variable to use them later 
        # during the podcast page creation
        podcast.data["references"] = get_podcast_references(reference_page.content, podcast.url)
        
        # Each podcast transcript splits into segements using the paragraph title
        # as the title of the segment. These segment splits are added manually but
        # we can avoid the need to also manually add their anchors by doing that here
        podcast.data["references"].each do |reference|
          reference["has_transcript_section"] = podcast.content.sub!(/^(_.*?#{Regexp.escape(reference["title"])}.*?_)/, "{:#{reference["slug"]}-transcript}\n \\1")
        end
      end
    end
  end

  def generate_slug(title)
    ## Remove double-quotes from titles before attempting to slugify
    title.gsub!('"', '')
    ## Use Liquid/Jekyll slugify filter to choose our id
    liquid_string = "\#{{ \"#{title}\" | slugify: 'latin' }}"
    slug = Liquid::Template.parse(liquid_string)
    # An empty context is used here because we only need to parse the liquid
    # string and don't require any additional variables or data.
    slug.render(Liquid::Context.new) 
  end

  def find_title(string, in_list=true, slugify=true)
    # this conditional prefix is for the special case of the review club section
    # which is not a list item (no dash (-) at the start of the line)
    prefix = in_list ? / *- / : // 

    # Find shortest match for **bold**, or [markdown][links]
    # note: when we are matching the title in `auto-anchor.rb` we also match *italics*
    # but on the newsletter sections nested bullets have *italics* titles therefore
    # by ignoring *italics* we are able to easier link to the outer title
    title = string.match(/^#{prefix}(?:\*\*(.*?):?\*\*|\[(.*?):?\][(\[])/)&.captures&.compact&.[](0) || ""
    if title.empty?
      {}
    else
      result = {"title"=> title}
      slug = slugify ? {"slug"=> generate_slug(title)} : {}
      result.merge!(slug)
    end
  end

  # This method searches the content for paragraphs that indicate that they are
  # part of a podcast recap. When a paragraph is part of a recap we:
  # - postfix with a link to the related podcast item 
  # - get the header, title and title slug of the paragraph to create
  #   the references for the podcast
  def get_podcast_references(content, target_page_url)
    # The logic here assumes that:
    # - paragraphs have headers
    # - each block of text (paragraph) is seperated by an empty line 
      
    # Split the content into paragraphs
    paragraphs = content.split(/\n\n+/)
    # Find all the headers in the content
    headers = content.scan(/^#+\s+(.*)$/).flatten

    # Create an array of hashes containing:
    # - the paragraph's title
    # - the paragraph's title slug
    # - the associated header
    # - the timestamp of the podcast in which this paragraph is discussed
    podcast_references = []
    current_header = 0
    current_title = {}
    in_review_club_section = false

    # Iterate over all paragraphs to find those with a podcast reference mark
    paragraphs.each do |p|
      # a title might have multiple paragraphs associated with it
      # the podcast reference mark might be at the end of an isolated
      # paragraph snippet that cannot access the title, therefore
      # we keep this information to be used in the link to the podcast recap
      title = find_title(p, !in_review_club_section)
      if !title.empty?
        # paragraph has title
        current_title = title
      end

      # If the current paragraph contains the podcast reference mark,
      # capture the timestamp, add paragraph to references and replace 
      # the mark with link to the related podcast item
      p.gsub!($podcast_reference_mark) do |match|
        if in_review_club_section
          # the newsletter's review club section is the only section that does
          # not have a list item to use as anchor so we use the header
          current_title["podcast_slug"] = "#pr-review-club" # to avoid duplicate anchor
          current_title["slug"] = "#bitcoin-core-pr-review-club"
        end
        podcast_reference = {"header"=> headers[current_header], "timestamp"=> $1}
        podcast_reference.merge!(current_title)
        podcast_references << podcast_reference

        # Replace the whole match with the link
        headphones_link = "[<i class='fa fa-headphones' title='Listen to our discussion of this on the podcast'></i>]"
        replacement_link_to_podcast_item = "#{headphones_link}(#{target_page_url}#{current_title["podcast_slug"] || current_title["slug"]})"
      end

      # update to the next header when parse through it
      if p.sub(/^#+\s*/, "") == headers[(current_header + 1) % headers.length()]
        current_header += 1
        in_review_club_section = headers[current_header] == "Bitcoin Core PR Review Club"
      end

    end

    # Join the paragraphs back together to return the modified content
    updated_content = paragraphs.join("\n\n")

    [updated_content, podcast_references]
  end
end