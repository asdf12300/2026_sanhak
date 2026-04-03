package model;

public class PagingVO {

    private int page;            // 현재 페이지
    private int totalCount;      // 전체 게시글 수
    private int totalPage;       // 전체 페이지 수
    private int startPage;       // 페이지네이션 시작 번호
    private int endPage;         // 페이지네이션 끝 번호
    private int pageSize = 10;   // 한 페이지 게시글 수(기본값 10)
    private int pageBlock = 5;   // 페이지 번호 몇 개씩 보일지 (5개 추천)

    public PagingVO(int page, int totalCount) {
        this.page = page;
        this.totalCount = totalCount;

        totalPage = (int)Math.ceil(totalCount / (double)pageSize);

        startPage = ((page - 1) / pageBlock) * pageBlock + 1;

        endPage = startPage + pageBlock - 1;

        if (endPage > totalPage) endPage = totalPage;
    }

    // Getter
    public int getPage() { return page; }
    public int getTotalCount() { return totalCount; }
    public int getTotalPage() { return totalPage; }
    public int getStartPage() { return startPage; }
    public int getEndPage() { return endPage; }
    public int getPageSize() { return pageSize; }
}
