function parseTickets (ticketsConfig, commitMsg) {
  const tickets = []

  ticketsConfig.forEach(ticketConfig => {
    const anyMatch = commitMsg.match(ticketConfig.pattern)
    if (anyMatch) {
      for (const match of commitMsg.matchAll(ticketConfig.pattern)) {
        const ticket = { }
        const multipleMatches = match.length > 1
        if (multipleMatches) {
          ticket.name = match[1] // get the first capture group
          ticket.fullMatch = match[0]
        } else {
          ticket.name = match[0]
        }
        ticket.link = ticketConfig.url.replace('$TICKET', ticket.name)
        const existingTicket = tickets.find(x => x.name === ticket.name)
        if (!existingTicket) {
          tickets.push(ticket)
        }
      }
    }
  })

  return tickets
}

module.exports = {
  parseTickets
}
