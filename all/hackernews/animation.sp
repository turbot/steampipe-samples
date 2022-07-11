/*
dashboard "AnimatedCompanyMentions" {

  tags = {
    service = "Hackernews"
  }

  container {

    chart {
      base = chart.companies_base
      width = 8
      type = "donut"
      title = "company mentions: 72 to 60 hours ago" // companies
      query = query.mentions
      args = [ local.companies, 4320, 3600 ] // companies
    }

    text {
      width = 8
      value = "run *python animate.py* to start the animation"
    }
  }

}
*/