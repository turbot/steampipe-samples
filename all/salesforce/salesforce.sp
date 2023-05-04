locals {
  lightning = "https://turbothqindiaprivateltd-dev-ed.lightning.force.com/lightning/"
}

dashboard "salesforce" {

  tags = {
    service = "salesforce"
  }

  container {

    title = "Quick facts"

    card {
      width = 2
      sql = <<EOQ
        select count(*) as contacts from salesforce_contact
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select count(*) as leads from salesforce_lead
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select count(*) as products from salesforce_product
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select count(*)  as "Q1 opportunities"

        from
          salesforce_opportunity
        where
          not is_won 
          and forecast_category = 'Pipeline'
          and fiscal_year::text = to_char(now(), 'YYYY')
      EOQ
    }

    card {
      width = 2
      sql = <<EOQ
        select count(*) as "Q1 wins"
        from
          salesforce_opportunity
        where
          is_won
          and fiscal_year::text = to_char(now(), 'YYYY')
          and fiscal_quarter = 1
      EOQ
    }

  }

  container {

    title = "Leads"

    chart {
      width = 5
      type = "donut"
      title = "by status"
      sql = <<EOQ
        select
          status,
          count(*)
        from 
          salesforce_lead
        group by
          status
      EOQ
    }

    table {
      width = 7
      title = "hot"
      sql = <<EOQ
        select
          name,
          id as link
        from 
          salesforce_lead
        where 
          status = 'Working - Contacted'
          and rating = 'Hot'
      EOQ
      column "link" {
         wrap = "all"
         href = "${local.lightning}r/Lead/{{.'link'}}/view"
      }
    }
    
  }

  container {

    title = "Contacts"

    chart {
      width = 5
      type = "donut"
      title = "by lead department"
      sql = <<EOQ
        select
          department,
          count(*)
        from 
          salesforce_contact
        where 
          department is not null
        group by
          department
      EOQ
    }

    chart {
      width = 5
      type = "donut"
      title = "by lead source"
      sql = <<EOQ
        select
          lead_source,
          count(*)
        from 
          salesforce_contact
        where
          lead_source is not null
        group by
          lead_source
      EOQ
    }

    table {
      width = 8
      title = "Twitter Activity"
      sql = <<EOQ
        with salesforce_info as (
          select
            id,
            name,
            twitter_username__c as twitter_username
          from 
            salesforce_contact
          where
            twitter_username__c is not null
          order by
            id
        )
        select
          s.name,
          'https://twitter.com/' || s.twitter_username as twitter_url,
          t.public_metrics->>'tweet_count' as tweets,
          t.public_metrics->>'followers_count' as followers
        from 
          salesforce_info s
        join
          twitter_user t
        on 
          s.twitter_username = t.username
      EOQ
    }  

  }


  container {
    title = "Today's Events"

    table {
      sql = <<EOQ
        select 
          e.start_date_time,
          e.subject,
          e.location,
          u.name as owner_name,
          a.name as account_name,
          c.name as contact_name
        from
          salesforce_event e
        join
          salesforce_account a on e.account_id = a.id
        join
          salesforce_contact c on e.who_id = c.id
        join
          salesforce_user u on e.owner_id = u.id
        --where
          --e.start_date_time::date = current_date
        order by 
          e.start_date_time desc
      EOQ
      column "link" {
        wrap = "all"
      }
    }

  }

  container {
    title = "Products"

    table {
      sql = <<EOQ
        select 
          *
        from
          salesforce_product
      EOQ
    }

  }


}
