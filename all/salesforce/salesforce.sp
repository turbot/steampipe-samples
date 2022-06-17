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

    title = "Contacts"

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

    chart {
      width = 5
      type = "donut"
      title = "by lead title"
      sql = <<EOQ
        select
          title,
          count(*)
        from 
          salesforce_contact
        where 
          title is not null
        group by
          title
      EOQ
    }

    
  }

  // https://turbothqindiaprivateltd-dev-ed.lightning.force.com/lightning/r/Event/00U5j00000FkDt6EAF/view

  container {
    title = "Today's Events"

    table {
      sql = <<EOQ
        select 
          '${local.lightning}r/Event/' || e.id || '/view' as link,
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
        where
          e.start_date_time::date = current_date
        order by 
          e.start_date_time desc
      EOQ
      column "link" {
        wrap = "all"
      }
    }


  }

}
