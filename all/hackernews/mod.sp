mod "hackernews" {
  title = "Hacker News"
}

locals {
  companies = [ 
    "Amazon",
    "AMD",
    "Apple",
    "CloudFlare",
    "Facebook",
    "GitLab",
    "Google",
    "IBM",
    "Intel ",
    "Microsoft",
    "Mozilla",
    "Netflix",
    "OpenAI",
    "Tesla",
    "TikTok",
    "Toshiba",
    "Twitter",
    "Sony",
    "SpaceX",
    "Stripe",
    "Uber",
    "Zendesk"
  ]

  languages = [
    "C#",
    "C\\+\\+",
    "Clojure",
    "CSS",
    "Erlang",
    "golang| go 1.| (in|with|using) go | go (.+)(compiler|template|monorepo|generic|interface|library|framework|garbage|module|range|source)",
    "Haskell",
    "HTML",
    "Java ",
    "JavaScript",
    "JSON",
    "PHP",
    "Python",
    "Rust ",
    "Scala ",
    "SQL",
    "Swift",
    "TypeScript",
    "WebAssembly|WASM",
    "XML"
  ]

  operating_systems = [
    "Android",
    "iOS",
    "Linux",
    "macOS| mac os ( *)x",
    "Windows"
  ]

  clouds = [
    "AWS",
    "Azure",
    "Google Cloud|GCP",
    "Oracle Cloud"
  ]

  dbs = [
    "DB2",
    "Citus",
    "CouchDB",
    "MongoDB",
    "MySQL|MariaDB",
    "Oracle",
    "Postgres",
    "Redis",
    "SQL Server",
    "Timescale",
    "SQLite",
    "Steampipe",
    "Supabase",
    "Yugabyte"
  ]

  editors = [
    " emacs ",
    " sublime ",
    "vscode| vs code |visual studio code",
    " vim "
  ]


}

# https://steampipe.io/docs/reference/mod-resources/dashboard#color

chart "companies_base" {
  series "mentions" {
    point "Amazon" {
      color = "Purple"
    }
    point "AMD" {
      color = "SandyBrown"
    }
    point "Apple" {
      color = "Crimson"
    }
    point "CloudFlare" {
      color = "Brown"
    }
    point "Facebook" {
      color = "RoyalBlue"
    }
    point "GitLab" {
      color = "#8C929D"
    }
    point "Google" {
      color = "SeaGreen"
    }
    point "IBM" {
      color = "#005d5d"
    }
    point "Intel" {
      color = "Wheat"
    }
    point "Microsoft" {
      color = "Blue"
    }
    point "Mozilla" {
      color = "#FFCB00"
    }
    point "Netflix" {
      color = "DarkRed"
    }
    point "OpenAI" {
      color = "#572F5F"
    }
    point "Tesla" {
      color = "Gray"
    }
    point "TikTok" {
      color = "Turquoise"
    }
    point "Toshiba" {
      color = "Goldenrod"
    }
    point "Twitter" {
      color = "PaleTurquoise"
    }
    point "Uber" {
      color = "Black"
    }
    point "Sony" {
      color = "Gold"
    }
    point "SpaceX" {
      color = "#22272B"
    }
    point "Stripe" {
      color = "SaddleBrown"
    }
  }  
}

chart "languages_base" {
  series "mentions" {
    point "C#" {
      color = "#823085"
    }
    point "C++" {
      color = "orange"
    }
    point "Clojure" {
      color = "#91DC47"
    }
    point "CSS" {
      color = "pink"
    }
    point "Erlang" {
      color = "DarkSalmon"
    }
    point "golang| go 1.| (in|with|using) go | go (.+)(compiler|template|monorepo|generic|interface|library|framework|garbage|module|range|source)" {
      color = "#4B8BBE"
    }
    point "Haskell" {
      color = "rgb(94,80,134)"
    }
    point "HTML" {
      color = "GoldenRod"
    }
    point "Java " {
      color = "#f89820"
    }
    point "JavaScript" {
      color = "#F0DB4F"
    }
    point "JSON" {
      color = "DarkSalmon"
    }
    point "PHP" {
      color = "beige"
    }
    point "Python" {
      color = "#306998"
    }
    point "Rust " {
      color = "black"
    }
    point "Scala " {
      color = "Coral"
    }
    point "SQL" {
      color = "ForestGreen"
    }
    point "Swift" {
      color = "#F05138"
    }
    point "TypeScript" {
      color = "white"
    }
    point "WebAssembly|WASM" {
      color = "#6856E7"
    }
    point "XML" {
      color = "DarkSeaGreen"
    }
  }
}

chart "os_base" {
  series "mentions" {
    point "Android" {
      color = "#78C257"
    }
    point "iOS" {
      color = "crimson"
    }
    point "macOS | mac os ( )*x" {
      color = "#a46859"
    }
    point "Windows" {
      color = "blue"
    }
    point "Linux" {
      color = "gray"
    }
  }
}

chart "cloud_base" {
  series "mentions" {
    point "AWS" {
      color = "#FF9900"
    }
    point "Azure" {
      color = "blue"
    }
    point "Google Cloud|GCP" {
      color = "#4285F4"
    }
    point "Oracle Cloud" {
      color = "red"
    }
  }
}

chart "db_base" {
  series "mentions" {
    point "DB2" {
      color = "brown"
    }
    point "Citus" {
      color = "green"
    }
    point "MongoDB" {
      color = "gray"
    }
    point "MySQL|MariaDB" {
      color = "orange"
    }
    point "Oracle" {
      color = "red"
    }
    point "Postgres" {
      color = "lightblue"
    }
    point "Steampipe" {
      color = "black"
    }
    point "Supabase" {
      color = "yellow"
    }
    point "Timescale" {
      color = "purple"
    }
    point "Scala" {
      color = "DarkCyan"
    }
    point "SQLite" {
      color = "purple"
    }
    point "Yugabyte" {
      color = "lightgreen"
    }

  }
}

chart "editor_base" {
  series "mentions" {
    point "Sublime" {
      color = "brown"
    }
    point "vscode| vs code |visual studio code" {
      color = "blue"
    }
    point "emacs" {
      color = "green"
    }
    point "vim" {
      color = "black"
    }
  }
}



