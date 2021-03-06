class Spinach::Features::Dashboard < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedPaths
  include SharedProject
  include SharedIssuable

  step 'I should see "New Project" link' do
    expect(page).to have_link "New project"
  end

  step 'I should see "Shop" project link' do
    expect(page).to have_link "Shop"
  end

  step 'I should see "Shop" project CI status' do
    expect(page).to have_link "Commit: skipped"
  end

  step 'I should see last push widget' do
    expect(page).to have_content "You pushed to fix"
    expect(page).to have_link "Create merge request"
  end

  step 'I click "Create merge request" link' do
    click_link "Create merge request"
  end

  step 'I see prefilled new Merge Request page' do
    expect(page).to have_selector('.merge-request-form')
    expect(current_path).to eq new_namespace_project_merge_request_path(@project.namespace, @project)
    expect(find("#merge_request_target_project_id").value).to eq @project.id.to_s
    expect(find("input#merge_request_source_branch").value).to eq "fix"
    expect(find("input#merge_request_target_branch").value).to eq "master"
  end

  step 'I have group with projects' do
    @group   = create(:group)
    @project = create(:empty_project, namespace: @group)
    @event   = create(:closed_issue_event, project: @project)

    @project.team << [current_user, :master]
  end

  step 'I should see projects list' do
    @user.authorized_projects.all.each do |project|
      expect(page).to have_link project.name_with_namespace
    end
  end

  step 'I should see groups list' do
    Group.all.each do |group|
      expect(page).to have_link group.name
    end
  end

  step 'group has a projects that does not belongs to me' do
    @forbidden_project1 = create(:empty_project, group: @group)
    @forbidden_project2 = create(:empty_project, group: @group)
  end

  step 'I should see 1 project at group list' do
    expect(find('span.last_activity/span')).to have_content('1')
  end

  step 'I filter the list by label "feature"' do
    page.within ".labels-filter" do
      find('.dropdown').click
      click_link "feature"
    end
  end

  step 'I should see "Bugfix1" in issues list' do
    page.within "ul.content-list" do
      expect(page).to have_content "Bugfix1"
    end
  end

  step 'project "Shop" has issue "Bugfix1" with label "feature"' do
    project = Project.find_by(name: "Shop")
    issue = create(:issue, title: "Bugfix1", project: project, assignees: [current_user])
    issue.labels << project.labels.find_by(title: 'feature')
  end
end
