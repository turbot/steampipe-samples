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
      title = "company mentions: 84 to 72 hours ago" 
      query = query.mentions
      args = [ local.companies, 5040, 4320 ] 
    }

    text {
      width = 8
      value = "run *python animate.py* to start the animation"
    }
  }

}
*/