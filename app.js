document.addEventListener('DOMContentLoaded', function () {
  const calendarEl = document.getElementById('calendar');
  const calendar = new FullCalendar.Calendar(calendarEl, {
    plugins: ['dayGrid', 'interaction', 'jquery-qtip'],
    header: {
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    },
    selectable: true,
    select: function (info) {
      const title = prompt('Event Title:');
      if (title) {
        calendar.addEvent({
          title: title,
          start: info.start,
          end: info.end,
          color: 'rgba(0, 123, 255, 0.3)' // Translucent blue color
        });
      }
      calendar.unselect();
    },
    events: [] // You can load existing events here if needed
  });

  calendar.render();
});
