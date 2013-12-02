# coding: utf-8
class MoviesCell < BaseCell
  helper :movies

  cache :recent_updated, :expires_in => 30.minutes
  def recent_updated
    @movies = Movie.recent_upload.limit(6)
    render
  end

  cache :newest, :expires_in => 30.minutes
  def newest
    @movies = Movie.has_attachs.newest.limit(6)
    render
  end

  cache :tagged_with_actors, :expires_in => 1.weeks do |cell, movie, opts|
    [movie.cache_key_by_version,opts,"v4.1"].join("")
  end
  def tagged_with_actors(movie, opts = {})
    @movies = Movie.tagged_with_on(:actors, movie.actors[0,2], :match => :any)
                   .and(:_id.ne => movie.id)
                   .has_attachs.desc(:score, :raters_count).limit(14)
    render
  end

  cache :tagged_with_tags, :expires_in => 1.weeks do |cell, args|
    args.cache_key_by_version(2)
  end
  def tagged_with_tags(movie)
    # TODO: 类似电影的匹配要用 all
    @movies = Movie.tagged_with_on(:tags, movie.tags[0,3], :match => :any)
                   .and(:_id.ne => movie.id)
                   .has_attachs.newest.limit(6)
    render
  end

end
