mongoose = require 'mongoose'
mongoose.connect 'mongodb://localhost/wikimine'

WikipediaChangeLogSchema = new mongoose.Schema {
  article: String
  diff_link: String
  diff: String
  old_id: String
  author: String
  change_count: String
  section: String
  message: String
}, { collection: 'WikipediaChangeLog' }

module.exports.WikipediaChangeLog = mongoose.model 'WikipediaChangeLog', WikipediaChangeLogSchema