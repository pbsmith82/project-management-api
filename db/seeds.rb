# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
DATA = {
    :project_type_keys =>
        ["name", "description"],
    :project_types => [
        ["Agile", "Agile focuses on effective response to change, comprehensive documentation and individuals interacting over processes and tools."],
        ["Scrum", "Scrum is a variation from the Agile methodology and is its most popular framework. It is simple to implement and solves many problems that software developers have faced."],
        ["Kanban", "Kanban is a methodology based on a team’s capacity to do work."],
        ["PMBOK", "This methodology encompasses the breakdown of different types of projects into five project groups agreed upon by the Project Management Institute (PMI)."],
        ["CCPM", "This methodology focuses primarily on the resources needed to complete a project and its tasks."]
    ],
    :project_keys =>
        ["title", "status", "description", "target_date", "start_date", "project_manager", "project_type_id"],
    :projects => [
        ["Captial EHR", "New", "New EHR for Capital Medical", "2022-02-05", "2021-02-05", "Phillip Smith", 1],
        ["Johnson Chat", "In Process", "New Internal Chat Application for Johnson Co.", "2022-03-05","2021-03-05", "David Park", 2],
        ["Carrier BI", "New", "New BI Application for Carrier LLC.", "2022-04-05","2021-04-05", "Mark Jackson", 3],
        ["Goodwin HR", "In Process", "A Human Resources Application for Goodwin Corp.", "2022-05-05","2021-05-05", "Brandon Hyrcyk" , 4],
        ["Micheals BluePrints", "Resolved", "Application to Store & Review Blueprints.", "2022-06-05","2021-06-05", "Sarah Howards", 5],
        ["Granger Documents", "Closed", "A Document Platform for Granger Industries.", "2022-07-05","2021-07-05", "Jennifer Donners", 1]
    ]
}

def main
    make_project_types
    make_projects
    # make_walks
end

def make_project_types
    DATA[:project_types].each do |type|
      new_type = ProjectType.new
      type.each_with_index do |attribute, i|
        new_type.send(DATA[:project_type_keys][i]+"=", attribute)
      end
      new_type.save
    end
end

def make_projects
    DATA[:projects].each do |project|
      new_project = Project.new
      project.each_with_index do |attribute, i|
        new_project.send(DATA[:project_keys][i]+"=", attribute)
      end
      new_project.save
    end
end

# def make_walks
#     Dog.all.each do |dog|
#      walk = dog.walks.build(distance: 1, fed: true, watered: true, user_id: dog.id)
#      walk.save
#     end
# end

main