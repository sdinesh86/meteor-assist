MeteorAssist = require '../lib/main'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "MeteorAssist", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('meteor-assist')

  describe "when the meteor-assist:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.ma-settings-view-wrapper')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'meteor-assist:toggle-settings-view'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.ma-settings-view-wrapper')).toExist()

        meteorAssistElement = workspaceElement.querySelector('.ma-settings-view-wrapper')
        expect(meteorAssistElement).toExist()
        console.log meteorAssistElement
        meteorAssistPanel = atom.workspace.panelForItem(meteorAssistElement)
        expect(meteorAssistPanel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'meteor-assist:toggle-settings-view'
        expect(meteorAssistPanel.isVisible()).toBe false

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.meteor-assist')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'meteor-assist:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        meteorAssistElement = workspaceElement.querySelector('.meteor-assist')
        expect(meteorAssistElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'meteor-assist:toggle'
        expect(meteorAssistElement).not.toBeVisible()
