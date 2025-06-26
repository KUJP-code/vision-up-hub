import ChartController from "@stimulus-components/chartjs"

export default class extends ChartController {
  async connect () {
    await super.connect()

    this.chart.options.animation = {
      duration: 0,

      onComplete: () => this._swapCanvasForPng()
      
    }

    this.chart.update()
  }

  _swapCanvasForPng () {
    const png  = this.chart.toBase64Image("image/png", 1)
    const img  = new Image()
    img.width  = this.chart.width
    img.height = this.chart.height
    img.setAttribute('data-chart-png', '')
    img.onload = () => {
      this.element.replaceWith(img)
      window.chartReady = true
    }

    img.src = png
  }
}
