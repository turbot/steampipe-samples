dashboard "my_reddit_posts" {
  
  tags = {
    service = "reddit"
  }

  title = "My reddit posts"

  table {
    sql = <<EOQ
      select
        author,
        subreddit,
        subreddit_subscribers as subscribers,
        score,
        rank,
        num_comments as comments,
        extract(days from now() - created_utc) as age_in_days,
        to_char(upvote_ratio, 'fm0.00') as upvote_ratio,
        title
      from 
        reddit_my_post
      order by
        score desc
    EOQ
    column "title" {
      wrap = "all"
    }
  }

}
