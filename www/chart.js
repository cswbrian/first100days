var Chart = (function(window,d3) {

   var svg, svgg, exampleData, maxValue, leftBarGroup, rightBarGroup, xScale, yScale, xScaleLeft, xScaleRight, xAxisLeft, xAxisRight, yAxisLeft, yAxisRight, margin = {}, width, height;
   init(); //load data, then initialize chart

function init() {
   // some contrived data
   exampleData = [
      {"week": 0,"cl": 861,"cy": 0},
      {"week": 1,"cl": 2163,"cy": 0},
      {"week": 2,"cl": 1792,"cy": 0},
      {"week": 3,"cl": 1867,"cy": 0},
      {"week": 4,"cl": 0,"cy": 194},
      {"week": 5,"cl": 0,"cy": 0},
      {"week": 6,"cl": 3039,"cy": 0},
      {"week": 7,"cl": 1777,"cy": 108},
      {"week": 8,"cl": 1665,"cy": 208},
      {"week": 9,"cl": 1895,"cy": 1149},
      {"week": 10,"cl": 1672,"cy": 903},
      {"week": 11,"cl": 2398,"cy": 298},
      {"week": 12,"cl": 1711,"cy": 86},
      ]; 

   // find the maximum data value on either side
   //  since this will be shared by both of the x-axes
   maxValue = Math.max(
     d3.max(exampleData, function(d) { return d.cy; }),
     d3.max(exampleData, function(d) { return d.cl; })
   );

  
   svg = d3.select('body').append('svg');
   
   svgg = svg.append('g');
   leftBarGroup = svgg.append('g').selectAll('.bar.left')
     .data(exampleData)
     .enter().append('rect')
     .attr('class', 'bar left')
     .attr('x', 0);
  
   rightBarGroup = svgg.append('g').selectAll('.bar.right')
     .data(exampleData)
     .enter().append('rect')
     .attr('class', 'bar right')
     .attr('x', 0);  
  
   xScale = d3.scale.linear();
   yScale = d3.scale.ordinal();
   xScaleLeft = d3.scale.linear();
   xScaleRight = d3.scale.linear();

   yAxisLeft = d3.svg.axis()
      .orient('right')
      .tickSize(0,0);
  
   yAxisRight = d3.svg.axis()
      .orient('left')
      .tickSize(0,0)
      .tickFormat('');

   xAxisLeft = d3.svg.axis()
     .orient('bottom')
     .tickFormat(d3.format(''));

   xAxisRight = d3.svg.axis()
     .orient('bottom')
     .tickFormat(d3.format(''));

   svgg.append('g').attr('class', 'axis y left');
   svgg.append('g').attr('class', 'axis y right');
   svgg.append('g').attr('class', 'axis x left');
   svgg.append('g').attr('class', 'axis x right');

   //render the chart
    render();
}


function render() {
   //get dimensions based on window size
   updateDimensions(window.innerWidth);
     
   // the width of each side of the chart
   var regionWidth = width/2 - margin.middle;

   // these are the x-coordinates of the y-axes
   var pointA = regionWidth,
       pointB = width - regionWidth;

  

   
   // CREATE SVG
   svg.attr('width', margin.left + width + margin.right)
      .attr('height', margin.top + height + margin.bottom);
     
   svgg.attr('transform', translation(margin.left, margin.top));
     // ADD A GROUP FOR THE SPACE WITHIN THE MARGINS
     

   // SET UP SCALES
     
   // the xScale goes from 0 to the width of a region
   //  it will be reversed for the left x-axis
   
   xScale.domain([0, maxValue])
     .range([0, regionWidth])
     .nice();

   yScale.domain(exampleData.map(function(d) { return d.week; }))
     .rangeRoundBands([height,0], 0.1);
  
   
  
   xScaleLeft
     .domain([0, maxValue])
     .range([regionWidth, 0]);

   xScaleRight
     .domain([0, maxValue])
     .range([0, regionWidth]);


   // SET UP AXES
   yAxisLeft.scale(yScale).tickPadding(margin.middle);
   yAxisRight.scale(yScale);

   // REVERSE THE X-AXIS SCALE ON THE LEFT SIDE BY REVERSING THE RANGE
   xAxisLeft.scale(xScale.copy().range([pointA, 0]));
   xAxisRight.scale(xScale);


   // MAKE GROUPS FOR EACH SIDE OF CHART
   // scale(-1,1) is used to reverse the left side so the bars grow left instead of right

   leftBarGroup.attr('transform', translation(pointA, 0) + 'scale(-1,1)');
   rightBarGroup.attr('transform', translation(pointB, 0));

   // DRAW AXES

   svg.selectAll('.axis.y.left')
     .attr('transform', translation(pointA, 0))
     .call(yAxisLeft)
     .selectAll('text')
     .style('text-anchor', 'middle');

   svg.selectAll('.axis.y.right')
     .attr('transform', translation(pointB, 0))
     .call(yAxisRight);

   svg.selectAll('.axis.x.left')
     .attr('transform', translation(0, height))
     .call(xAxisLeft);

   svg.selectAll('.axis.x.right')
     .attr('transform', translation(pointB, height))
     .call(xAxisRight);

   // DRAW BARS
   leftBarGroup
       .attr('y', function(d) { return yScale(d.week); })
       .attr('width', function(d) { return xScale(d.cy); })
       .attr('height', yScale.rangeBand());

   rightBarGroup
       .attr('y', function(d) { return yScale(d.week); })
       .attr('width', function(d) { return xScale(d.cl); })
       .attr('height', yScale.rangeBand());
  
}

// so sick of string concatenation for translations
function translation(x,y) {
  return 'translate(' + x + ',' + y + ')';
}

function updateDimensions(winWidth) {
   margin = {
     top: 20,
     right: 20,
     bottom: 24,
     left: 20,
     middle: 15
     // margin.middle is distance from center line to each y-axis
   };
       
   console.log(winWidth);
 width = winWidth - margin.left - margin.right;
 height = 600 - margin.top - margin.bottom;
}


return {
 render : render
}

})(window,d3);

window.addEventListener('resize', Chart.render);
