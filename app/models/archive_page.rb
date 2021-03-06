class ArchivePage < Page

  description %{
    An archive page provides behavior similar to a blog archive or a news
    archive. Child page URLs are altered to be in %Y/%m/%d format
    (2004/05/06).
    
    An archive page can be used in conjunction with the "Archive Year Index",
    "Archive Month Index", and "Archive Day Index" page types to create year,
    month, and day indexes.
  }
  
  def child_url(child)
    @year, @month, @day = $1, ($2 || 1).to_i, ($3 || 1).to_i if child.request and child.request.request_uri =~ %r{/(\d{4})(?:/(\d{2})(?:/(\d{2}))?)?/?$}
    date = (@year ? Date.new(@year.to_i, @month, @day) : (child.published_at || Time.now))

    if ArchiveYearIndexPage === child
      clean_url "#{ url }/#{ date.strftime '%Y' }/"
    elsif ArchiveMonthIndexPage === child
      clean_url "#{ url }/#{ date.strftime '%Y/%m' }/"
    elsif ArchiveDayIndexPage === child
      clean_url "#{ url }/#{ date.strftime '%Y/%m/%d/' }/"
    else
      clean_url "#{ url }/#{ date.strftime '%Y/%m/%d' }/#{ child.slug }"
    end
  end
  
  def find_by_url(url, live = true, clean = false)
    url = clean_url(url) if clean
    if url =~ %r{^#{ self.url }(\d{4})(?:/(\d{2})(?:/(\d{2}))?)?/?$}
      year, month, day = $1, $2, $3
      children.find_by_class_name(
        case
        when day
          'ArchiveDayIndexPage'
        when month
          'ArchiveMonthIndexPage'
        else
          'ArchiveYearIndexPage'
        end
      )
    else
      super
    end
  end
end
