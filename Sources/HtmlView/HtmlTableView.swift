import SwiftUI
import SwiftSoup

struct HtmlTableView: View, Equatable {
    public init(element: Element) {
        self.element = element
        
        let (headers, rows) = HtmlTableView.parseHTMLTable(element: element)
        self.headers = headers
        self.rows = rows
    }
    
    let element: Element
    let headers: [String]
    let rows: [[String]]

    static func parseHTMLTable(element: Element) -> ([String], [[String]]) {
        var headers = [String]()
        var rows = [[String]]()

        do {
            let headerElements = try element.select("th")
            headers = try headerElements.array().map { try $0.text() }
            
            let rowElements = try element.select("tr").array()
            for rowElement in rowElements {
                let dataElements = try rowElement.select("td").array()
                let rowData = try dataElements.map { try $0.text() }
                if !rowData.isEmpty {
                    rows.append(rowData)
                }
            }
        } catch Exception.Error(_, let message) {
            print(message)
        } catch {
            print("error")
        }

        return (headers, rows)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(headers, id: \.self) { header in
                    Text(header)
                        .font(.caption2)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(2)
                }
            }
            ForEach(0..<rows.count, id: \.self) { index in
                Divider()
                HStack {
                    ForEach(rows[index], id: \.self) { cell in
                        Text(cell)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.caption2)
                    }
                }
            }
        }
    }
}

#Preview {
    let html = """
    <table>
       <thead>
          <tr>
             <th>Region</th>
             <th>DNS (ms)</th>
             <th>Connection (ms)</th>
             <th>TLS Handshake (ms)</th>
             <th>TTFB (ms)</th>
             <th>Transfert (ms)</th>
          </tr>
       </thead>
       <tbody>
          <tr>
             <td>AMS</td>
             <td>17</td>
             <td>2</td>
             <td>17</td>
             <td>27</td>
             <td>0</td>
          </tr>
          <tr>
             <td>GRU</td>
             <td>38</td>
             <td>2</td>
             <td>13</td>
             <td>28</td>
             <td>0</td>
          </tr>
          <tr>
             <td>HKG</td>
             <td>19</td>
             <td>2</td>
             <td>13</td>
             <td>29</td>
             <td>0</td>
          </tr>
          <tr>
             <td>IAD</td>
             <td>24</td>
             <td>1</td>
             <td>14</td>
             <td>30</td>
             <td>0</td>
          </tr>
          <tr>
             <td>JNB</td>
             <td>123</td>
             <td>168</td>
             <td>182</td>
             <td>185</td>
             <td>0</td>
          </tr>
          <tr>
             <td>SYD</td>
             <td>51</td>
             <td>1</td>
             <td>11</td>
             <td>25</td>
             <td>0</td>
          </tr>
       </tbody>
    </table>
    """
    let tableElem = try! SwiftSoup.parse(html).select("table").first()!
    return HtmlTableView(
        element: tableElem
    ).equatable()
    .padding()
}
